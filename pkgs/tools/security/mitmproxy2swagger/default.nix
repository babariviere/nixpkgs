{ lib
, fetchFromGitHub
, python3
}:

let
  python = python3.override {
    packageOverrides = final: prev: {
      # https://github.com/alufers/mitmproxy2swagger/issues/27
      json-stream = prev.json-stream.overridePythonAttrs (old: rec {
        version = "1.5.1";
        src = old.src.override {
          inherit version;
          hash = "sha256-htajifmbXtivUwsORzBzJA68nJCACcL75kiBysVYCxY=";
        };
      });
    };
  };
in

python.pkgs.buildPythonApplication rec {
  pname = "mitmproxy2swagger";
  version = "0.7.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alufers";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-LnH0RDiRYJAGI7ZT6Idu1AqSz0yBRuBJvhIgY72Z4CA=";
  };

  nativeBuildInputs = with python.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python.pkgs; [
    json-stream
    mitmproxy
    ruamel-yaml
  ];

  # No tests available
  doCheck = false;

  pythonImportsCheck = [
    "mitmproxy2swagger"
  ];

  meta = with lib; {
    description = "Tool to automagically reverse-engineer REST APIs";
    homepage = "https://github.com/alufers/mitmproxy2swagger";
    changelog = "https://github.com/alufers/mitmproxy2swagger/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
