; Script generado por Inno Setup Script Wizard.

#define MyAppName "Sorteo Regalon Footloose"
#define MyAppVersion "1.1.0(6)"
#define MyAppPublisher "Footloose Peru"
#define MyAppURL "https://www.footloose.pe/"
#define MyAppExeName "raffle_footloose.exe"
#define ReleaseFolder "C:\Users\jean.juarez\Desktop\data\FootlooseApps\raffle_footloose\build\windows\x64\runner\Release"

[Setup]
AppId={{5055744E-5060-48A4-9A10-E12AD41A977D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\SorteoRegalonFootloose
DisableProgramGroupPage=yes
OutputDir=C:\Users\jean.juarez\Desktop\data\FootlooseApps\raffle_footloose\installerss
OutputBaseFilename=sorteo_regalon_installer_v1.1.0(6)
SetupIconFile=C:\Users\jean.juarez\Desktop\data\FootlooseApps\raffle_footloose\lib\assets\favicon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; ✅ Copia todo el contenido del Release (EXE, DLLs, plugins, icudtl.dat, etc.)
Source: "{#ReleaseFolder}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; ✅ Ícono de la app
Source: "C:\Users\jean.juarez\Desktop\data\FootlooseApps\raffle_footloose\lib\assets\favicon.ico"; DestDir: "{app}"; DestName: "favicon.ico"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\favicon.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\favicon.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
