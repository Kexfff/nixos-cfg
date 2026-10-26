# Git + delta + lazygit + GitHub CLI.
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Aleksei";
        email = "llexxass@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rebase.autoStash = true;
      rerere.enabled = true;
      diff.colorMoved = "default";
      merge.conflictStyle = "zdiff3";
      # Commit signing (SSH key):
      # gpg.format = "ssh";
      # user.signingKey = "~/.ssh/id_ed25519.pub";
      # commit.gpgSign = true;
    };
    ignores = [
      "result"
      "result-*"
      ".direnv/"
      ".envrc.local"
      "*.swp"
      ".DS_Store"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  programs.lazygit.enable = true;

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
