{
  #lsd shortcut
  ls = "lsd";
  ll = "lsd -l";
  la = "lsd -a";
  lla = "lsd -la";
  lts = "lsd -la --total-size";
  ".." = "cd ..";
  "..." = "cd ../..";
  g = "git";
  #nix update shortcut
  rebuildlap = "sudo nixos-rebuild switch --flake ~/.dotfile/.#laptop";
  rebuilddesk = "sudo nixos-rebuild switch --flake ~/.dotfile/.#desktop";
  updatehost = "sudo nix flake update ~/.flake";
  #emacs shortcut
  e = "emacsclient -a 'emacs' -c";
  et = "emacsclient -a 'emacs' -t";
  # man = "emacs -nw --eval '(progn (man \"'$1'\") (delete-window))'";

  nd = "nix develop";
  np = "nix-shell";
  nfu = "nix flake update";
  cr = "cargo run";

  c = "codium";
  # Git
  gs = "git status";
  gch = "git checkout";
  gpus = "git push";
  gpul = "git pull";
}
