{
  inputs
, inputs'
, pkgs
, haskellProject
, ghc
, system 
, enableProfiling
, 
}:
{
  enabled = true;
  buildSystems = ["x86_64-darwin" "x86_64-linux"];
  crossSystem = "x86_64-linux";
  excludeProfiledHaskell = true;
  blacklistedJobs = [];
  enablePreCommitCheck = true;
  extraJobs = {};
}






