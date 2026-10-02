{ pkgs, lib, ... }:
let
  dotnet-full =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      runtime_8_0
      aspnetcore_8_0
      sdk_9_0
      runtime_9_0
      aspnetcore_9_0
      sdk_10_0
      runtime_10_0
      aspnetcore_10_0
    ];

  deps = (
    ps:
    with ps;
    [
      rustup
      zlib
      openssl.dev
      pkg-config
      stdenv.cc
      cmake
      mono
      msbuild
      libsecret
    ]
    ++ [ dotnet-full ]
  );

  marketplaceExtensions = [
    #UPDATE AS NEEDED
    #This is a massive pain in the ass. Automate this at some point...
    {
      name = "LiveServer";
      publisher = "ritwickdey";
      version = "5.7.10";
      sha256 = "sha256-D474GdTCAH8b+zuO+1M+cnluKfBv7mAMdtH7F777W5U=";
    }
    {
      name = "mono-debug";
      publisher = "ms-vscode";
      version = "0.16.3";
      sha256 = "sha256-6IU8aP4FQVbEMZAgssGiyqM+PAbwipxou5Wk3Q2mjZg=";
    }
    {
      name = "llvm";
      publisher = "RReverser";
      version = "0.2.0";
      sha256 = "sha256-roAZROFvQSwDiGRR7N1RUT0DEtKk555uo2FFgvBz02M=";
    }
    {
      name = "Go";
      publisher = "golang";
      version = "0.57.0";
      sha256 = "sha256-q3YnRT1CyD5/lLQ3sIewW4yGkBGbGZxTrnceAC6+qMU=";
    }
    {
      name = "html-snippets";
      publisher = "abusaidm";
      version = "0.2.1";
      sha256 = "sha256-mps1lMruuA6cb4kae0J3bMNJPb1uIQAb7jjy9aDn2Oc=";
    }
    {
      name = "godot-csharp-vscode";
      publisher = "neikeq";
      version = "0.2.1";
      sha256 = "sha256-sLsP+4deo/O8NjHGGXVdSOPWQPALypW/H0oZOMMM9RE=";
    }
    {
      #Update frequently
      name = "vscode-pgsql";
      publisher = "ms-ossdata";
      version = "1.28.0";
      sha256 = "sha256-+mZEYMrRwjsDXCHzNzYHFO+lhDSmpuL4D4uQAS+71v8=";
    }
    {
      name = "vscode-avalonia";
      publisher = "AvaloniaTeam";
      version = "12.3.1";
      sha256 = "sha256-UzOLSDBB4gAo/YVckcYqesDNdgmgGwUsVueTD6RTWvw=";
    }
  ];
in
{
  programs.vscode = {
    enable = true;
    package =
      (pkgs.vscode.overrideAttrs (prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgs.makeWrapper ];
        postFixup =
          prevAttrs.postFixup
          + ''
            wrapProgram $out/bin/code \
              --set DOTNET_ROOT "${dotnet-full}" \
              --prefix PATH : "~/.dotnet/tools"
          '';
      })).fhsWithPackages
        (ps: deps ps);
    extensions = (with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      redhat.vscode-yaml
      ms-dotnettools.vscode-dotnet-runtime
      ms-dotnettools.csharp
      ms-dotnettools.csdevkit
      christian-kohler.path-intellisense
      donjayamanne.githistory
      ms-vscode.hexeditor
      rust-lang.rust-analyzer
      geequlim.godot-tools
      jnoortheen.nix-ide
      dbaeumer.vscode-eslint
      
    ]) ++ (map (ext: pkgs.vscode-utils.extensionFromVscodeMarketplace ext) marketplaceExtensions);
  };
}