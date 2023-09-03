{ rustPlatform, pkgs, fetchFromGitHub, lib, installShellFiles, ... }:
rustPlatform.buildRustPackage rec {
  pname = "nixer";
  version = "0.1.0";

  src = builtins.fetchGit {
    url = "git@github.com:Tol0kk/nixer.git";
    ref = "main";
    rev = "7b57ab92b178cb3a63a59b2059bb314ef797e866";
  };

  cargoHash = "sha256-44Kqc9TTxZ1PLFaDNrBz8Pwg+7IkX91HfIB5fJsRpl8=";

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    installShellCompletion --cmd nixer \
      --bash <($out/bin/nixer --gen-completions bash) \
      --fish <($out/bin/nixer --gen-completions fish)
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/Tol0kk/nixer";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ Tol0kk ];
  };
}


