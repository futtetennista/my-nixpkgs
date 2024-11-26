{ pkgs
, stdenv
, makeWrapper
, postgresql
, version
}:

let
  psqlrc = pkgs.writeText "psqlrc" ''
    \encoding UTF8

    -- [user]@[host]:[port]/[db]['*' if we are in a transaction]['#' if we are root-like; '>' otherwise]
    \set PROMPT1 '%n|%M:%>/%/%x%# '

    -- Ensure second prompt is empty, to facilitate easier copying
    -- of multiline SQL statements from a psql session into other
    -- tools / text editors.
    \set PROMPT2 ' '

    -- Ensure autocompleted keywords stay lowercase.
    \set COMP_KEYWORD_CASE lower

    -- Make history ignore all lines entered that were preceded by spaces, and
    -- ignore any entries that matched the previous line entered.
    \set HISTCONTROL ignoreboth

    \set HISTFILE ~/.psql_history- :DBNAME - :USER

    \set HISTSIZE 1000

    \set AUTOCOMMIT off

    -- In interactive transactions, allow recovery after errors within
    -- transactions. In non-interactive transactions - e.g. those in piped
    -- input - do not.
    \set ON_ERROR_ROLLBACK interactive

    \set IGNOREEOF 2

    \pset null '[NULL]'

    \pset linestyle unicode

    \pset border 2

    \timing

    \x on

    \i ~/.psqlrc
  '';
in
stdenv.mkDerivation {
  name = "postgresql";
  buildInputs = [ makeWrapper postgresql ];
  phases = [ "fixupPhase" ];
  postFixup = ''
    mkdir -p $out/bin
    cp -r ${postgresql}/bin/* $out/bin
    # mv $out/bin/psql $out/bin/psql_
    makeWrapper $out/bin/psql $out/bin/psql_${toString version} --set-default PSQLRC ${psqlrc}
  '';
}
