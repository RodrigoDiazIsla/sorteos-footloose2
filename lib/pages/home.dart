import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/helpers/logs.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/model/winners_model.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/providers/winners_provider.dart';
import 'package:raffle_footloose/widgets/alert_notification.dart';
import 'package:raffle_footloose/widgets/card_raffle.dart';
import 'package:raffle_footloose/widgets/card_winners.dart';
import 'package:raffle_footloose/widgets/image_logo.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  int countParticipants = -1;
  int countWinners = 0;
  bool loading = false;
  WinnersModel currentWinner = WinnersModel();


  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    final QueryService query = QueryService();
    ref.read(raffleProvider.notifier).getRaffle();


    countParticipants = await query.fetchCountParticipants();

    infoLog("count_participants", countParticipants.toString());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobile();

    final theme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            "SORTEOS FOOTLOOSE",
            style: TextStyle(color: const Color(0xFF6F359C), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6F359C)),
              onPressed: () => ref.invalidate(winnersStreamProvider),
              tooltip: "Refrescar lista",
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),

              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF6F359C).withOpacity(0.1)),
                icon: const Icon(Icons.table_view_rounded, color: Color(0xFF6F359C)),
                onPressed: () async {
                  final QueryService query = QueryService();
                  await query.exportAndOpenExcel("reporte_ganadores_footloose");
                },
                tooltip: "Exportar a Excel",
              ),
            ),
          ],
        ),
        body: Container(

          color: Theme.of(context).scaffoldBackgroundColor,

          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ImageLogo(),
                  ),
                  const Divider(height: 1, color: Colors.white10),

                  Padding(
                    padding: EdgeInsets.only(top: mobile ? 20 : 40),
                    child: CardRaffle(countParticipants: countParticipants),
                  ),
                  SizedBox(
                    width: mobile ? (MediaQuery.of(context).size.width * 0.95) : 800,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: mobile ? 20 : 60),
                      child: Column(
                        children: [
                          ref.watch(winnersStreamProvider).when(
                                data: (winners) => CardWinners(listWinners: winners),
                                loading: () => const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                                error: (e, _) => Text("Error: $e"),
                              )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}
