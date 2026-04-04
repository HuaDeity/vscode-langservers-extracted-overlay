{ ... }:
{
  hercules-ci.flake-update = {
    enable = true;
    baseMerge.enable = true;
    baseMerge.method = "rebase";
    autoMergeMethod = "rebase";
    # Update every night at midnight UTC
    when = {
      hour = [ 0 ];
      minute = 0;
    };
  };
}
