{ dockerTools, bech32 }:

dockerTools.buildImage {
  name = "bech32docker";
  config = {
    Entrypoint = [ "${bech32}/bin/bech32" ];
  };
}
