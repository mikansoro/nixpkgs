{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
  clusterawsadm,
}:

buildGoModule rec {
  pname = "clusterawsadm";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "cluster-api-provider-aws";
    rev = "v${version}";
    hash = "sha256-l2ZCylr47vRYw/HyYaeKfSvH1Kt9YQPwLoHLU2h+AE4=";
  };

  vendorHash = "sha256-iAheoh9VMSdTVvJzhXZBFpGDoDsGO8OV/sYjDEsf8qw=";

  subPackages = [ "cmd/clusterawsadm" ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags =
    let
      t = "sigs.k8s.io/cluster-api-provider-aws/v2";
    in
    [
      "-X ${t}/version.gitMajor=${lib.versions.major version}"
      "-X ${t}/version.gitMinor=${lib.versions.minor version}"
      "-X ${t}/version.gitVersion=v${version}"
      "-X ${t}/cmd/clusterawsadm/cmd/version.CLIName=clusterctl-aws"
    ];

  postInstall = ''
    # errors attempting to write config to read-only $HOME
    export HOME=$TMPDIR

    installShellCompletion --cmd clusterctl \
      --bash <($out/bin/clusterctl completion bash) \
      --fish <($out/bin/clusterctl completion fish) \
      --zsh <($out/bin/clusterctl completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = clusterawsadm;
    command = "HOME=$TMPDIR clusterawsadm version";
    version = "v${version}";
  };

  meta = {
    changelog = "https://github.com/kubernetes-sigs/cluster-api/releases/tag/${src.rev}";
    description = "Kubernetes cluster API aws integration utility";
    mainProgram = "clusterawsadm";
    homepage = "https://cluster-api-aws.sigs.k8s.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mikansoro ];
  };
}
