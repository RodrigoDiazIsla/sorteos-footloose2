import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/helpers/logs.dart';
import 'package:raffle_footloose/helpers/image_picker_stub.dart'
    if (dart.library.io) 'package:raffle_footloose/helpers/image_picker_io.dart'
    if (dart.library.html) 'package:raffle_footloose/helpers/image_picker_web.dart';
import 'package:raffle_footloose/providers/raffle_image_provider.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/providers/winners_provider.dart';
import 'package:raffle_footloose/widgets/card_raffle.dart';
import 'package:raffle_footloose/widgets/card_winners.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  int countParticipants = -1;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    final QueryService query = QueryService();
    ref.read(raffleProvider.notifier).getRaffle();
    ref.read(raffleImageProvider.notifier).loadImage();

    countParticipants = await query.fetchCountParticipants();
    infoLog('count_participants', countParticipants.toString());

    if (mounted) setState(() {});
  }

  Future<void> _showChangeImageDialog(BuildContext context) async {
    final currentImage = ref.read(raffleImageProvider) ?? '';

    await showDialog<void>(
      context: context,
      builder: (_) => _ChangeImageDialog(initialImage: currentImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 700;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: mobile ? 8 : 24,
          title: Row(
            children: [
              Image.asset(
                'lib/assets/logo_purple.png',
                height: mobile ? 28 : 34,
                fit: BoxFit.contain,
              ),
              SizedBox(width: mobile ? 8 : 14),
              Flexible(
                child: Text(
                  mobile ? 'Sorteos' : 'Sorteos Footloose',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF3B0764),
                    fontWeight: FontWeight.w800,
                    fontSize: mobile ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (!mobile)
              TextButton.icon(
                onPressed: () => _showChangeImageDialog(context),
                icon: const Icon(
                  Icons.image_rounded,
                  color: Color(0xFF6F359C),
                  size: 18,
                ),
                label: const Text(
                  'Cambiar imagen sorteo',
                  style: TextStyle(
                    color: Color(0xFF6F359C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              IconButton.filledTonal(
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                iconSize: 20,
                icon: const Icon(Icons.image_rounded, color: Color(0xFF6F359C)),
                onPressed: () => _showChangeImageDialog(context),
                tooltip: 'Cambiar imagen sorteo',
              ),
            IconButton.filledTonal(
              constraints: BoxConstraints.tightFor(
                width: mobile ? 40 : 48,
                height: mobile ? 40 : 48,
              ),
              iconSize: mobile ? 20 : 24,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6F359C)),
              onPressed: () => ref.invalidate(winnersStreamProvider),
              tooltip: 'Refrescar lista',
            ),
            Padding(
              padding: EdgeInsets.only(
                right: mobile ? 8 : 16,
                left: mobile ? 4 : 8,
              ),
              child: IconButton.filled(
                constraints: BoxConstraints.tightFor(
                  width: mobile ? 40 : 48,
                  height: mobile ? 40 : 48,
                ),
                iconSize: mobile ? 20 : 24,
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF6F359C)),
                icon: const Icon(Icons.table_view_rounded, color: Colors.white),
                onPressed: () async {
                  final QueryService query = QueryService();
                  await query.exportWinnersReport('reporte_ganadores_footloose');
                },
                tooltip: 'Exportar a Excel',
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 980;
            final bool tv = constraints.maxWidth >= 1500;
            final double horizontalPadding = mobile ? 10 : (tv ? 40 : 28);
            final double maxContentWidth = tv ? 1580 : 1240;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      mobile ? 12 : 24,
                      horizontalPadding,
                      48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: CardRaffle(countParticipants: countParticipants),
                              ),
                              const SizedBox(width: 24),
                              const Expanded(
                                flex: 4,
                                child: _WinnersPanel(),
                              ),
                            ],
                          )
                        else ...[
                          CardRaffle(countParticipants: countParticipants),
                          const SizedBox(height: 24),
                          const _WinnersPanel(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChangeImageDialog extends ConsumerStatefulWidget {
  final String initialImage;

  const _ChangeImageDialog({required this.initialImage});

  @override
  ConsumerState<_ChangeImageDialog> createState() => _ChangeImageDialogState();
}

class _ChangeImageDialogState extends ConsumerState<_ChangeImageDialog> {
  late final TextEditingController _controller;
  bool _loadingUpload = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialImage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Cambiar imagen del sorteo'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'URL de imagen',
          hintText: 'https://.../banner.png',
          prefixIcon: Icon(Icons.link_rounded, color: Color(0xFF6F359C)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loadingUpload
              ? null
              : () async {
                  await ref.read(raffleImageProvider.notifier).clearImage();
                  if (mounted) Navigator.pop(context);
                },
          child: const Text(
            'USAR DEFAULT',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton.icon(
          onPressed: _loadingUpload
              ? null
              : () async {
                  setState(() => _loadingUpload = true);
                  final dataUrl = await pickRaffleImageDataUrl();
                  if (dataUrl != null && dataUrl.isNotEmpty) {
                    await ref.read(raffleImageProvider.notifier).setImage(dataUrl);
                    if (mounted) Navigator.pop(context);
                  } else if (mounted) {
                    setState(() => _loadingUpload = false);
                  }
                },
          icon: _loadingUpload
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_rounded, size: 18),
          label: Text(_loadingUpload ? 'CARGANDO...' : 'SUBIR IMAGEN'),
        ),
        TextButton(
          onPressed: _loadingUpload ? null : () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6F359C)),
          onPressed: _loadingUpload
              ? null
              : () async {
                  await ref.read(raffleImageProvider.notifier).setImage(_controller.text);
                  if (mounted) Navigator.pop(context);
                },
          child: const Text('GUARDAR URL'),
        ),
      ],
    );
  }
}

class _WinnersPanel extends ConsumerWidget {
  const _WinnersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(winnersStreamProvider).when(
          data: (winners) => CardWinners(listWinners: winners),
          loading: () => const _LoadingPanel(),
          error: (e, _) => _ErrorPanel(error: e.toString()),
        );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const CircularProgressIndicator(color: Color(0xFFD4AF37)),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String error;

  const _ErrorPanel({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Color(0xFFEF4444)),
      ),
    );
  }
}
