defnix: let
  inherit (defnix.pkgs) multiplex-activations emulate-inetd execve sshd;

  inherit (defnix.defnixos.activations) socket;

  inherit (defnix.lib.socket-address-families) AF_INET6;
in { passwd, group, port, config }: {
  start = multiplex-activations [
    (socket { family = AF_INET6; inherit port; })
  ] (emulate-inetd (execve "run-sshd" {
    filename = sshd;

    argv = [ "sshd" "-D" "-f" config "-i" ];

    settings.bind-mounts = {
      "/etc/passwd" = passwd;

      "/etc/group" = group;

      # TODO: run private nscd instance instead
      "/var/run/nscd" = "/var/empty";
    };
  }));

  on-demand = true;
}
