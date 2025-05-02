{
  #lsd shortcut
  ls = "lsd";
  ll = "lsd -l";
  la = "lsd -a";
  lla = "lsd -la";
  lts = "lsd -la --total-size";

  ".." = "cd ..";
  "..." = "cd ../..";

  # Git
  g = "git";
  gd = "git diff";
  ga = "git add";
  gc = "git commit";
  gp = "git push";
  gu = "git pull";
  gl = "git log";
  gb = "git branch";
  gi = "git init";
  gcl = "git clone";
  gs = "git status";

  #nix update shortcut
  switchsys = "sudo nixos-rebuild switch --flake ~/.config/nixos";
  switchhome = "sudo nixos-rebuild switch --flake ~/.config/nixos";
  #emacs shortcut
  e = "emacsclient -a 'emacs' -c";
  et = "emacsclient -a 'emacs' -t";
  # man = "emacs -nw --eval '(progn (man \"'$1'\") (delete-window))'";

  nd = "nix develop";
  np = "nix-shell -p";
  nfu = "nix flake update";
  cr = "cargo run";

  c = "codium";
}
