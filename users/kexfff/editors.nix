# Editors: VS Code (FHS build, so extensions with native binaries work) and Zed.
{ pkgs, ... }:
{
  programs.vscode = {
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

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;
    extensions = [
      "nix"
      "toml"
    ];
  };

  # JetBrains: add pkgs.jetbrains.idea-community to home.packages in ./home.nix
}
