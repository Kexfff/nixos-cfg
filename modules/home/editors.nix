# Editors configured through Home Manager; the list follows my.development.editors.
{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  dev = osConfig.my.development;
  want = e: dev.enable && builtins.elem e dev.editors;
in
{
  programs.vscode = lib.mkIf (want "vscode") {
    enable = true;
    package = pkgs.vscode-fhs;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        mkhl.direnv
        eamodio.gitlens
        usernamehw.errorlens
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        ms-python.python
        kilocode.kilo-code
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "nixfmt";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
        "editor.fontLigatures" = true;
        "editor.formatOnSave" = true;
        "files.autoSave" = "onFocusChange";
        "window.titleBarStyle" = "custom";
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.commandsToSkipShell" = [
          "kilo-code.new.agentManagerOpen"
          "kilo-code.new.agentManager.showTerminal"
          "kilo-code.new.agentManager.previousTerminal"
          "kilo-code.new.agentManager.nextTerminal"
        ];
        "kilo-code.new.agentWorkStyle" = "skipped";
      };
    };
  };

  programs.zed-editor = lib.mkIf (want "zed") {
    enable = true;
    extensions = [
      "nix"
      "toml"
    ];
  };

  home.packages =
    lib.optional (want "jetbrains-idea") pkgs.jetbrains.idea-community
    ++ lib.optionals (want "vscode") [
      pkgs.nixd
      pkgs.nixfmt
    ];
}
