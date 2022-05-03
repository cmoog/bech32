{ dockerTools, bech32, self }:

dockerTools.buildImage {
  name = "bech32docker";
  tag = self.shortRev or "dirty";
  config = {
    Entrypoint = [ "${bech32}/bin/bech32" ];
  };
}
