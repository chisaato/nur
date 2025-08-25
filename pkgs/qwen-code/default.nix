{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  writeShellApplication,
  importNpmLock,
  cacert,
  curl,
  gnused,
  jq,
  nix-prefetch-github,
  prefetch-npm-deps,
}:

buildNpmPackage (finalAttrs: {
  pname = "qwen-code";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "QwenLM";
    repo = "qwen-code";
    # Currently there's no release tag
    rev = "v0.0.8";
    hash = "sha256-JHy7I/SLja0zlaB9YFFpz/fI898FTyo+KDBD3eTk3rg=";
  };

  # npmDeps = fetchNpmDeps {
  #   inherit (finalAttrs) src;
  #   hash = "sha256-g6tm5Bj5HQ8COf0aKbXyittWheS3ZHp4DKW7FALl6no=";
  # };
  npmDepsHash = "sha256-g6tm5Bj5HQ8COf0aKbXyittWheS3ZHp4DKW7FALl6no=";

  # npmFlags = [ "--legacy-peer-deps" ];
  # makeCacheWritable = true;

  preConfigure = ''
    mkdir -p packages/generated
    echo "export const GIT_COMMIT_INFO = { commitHash: '${finalAttrs.src.rev}' };" > packages/generated/git-commit.ts
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib"

    cp -r node_modules "$out/lib/"

    rm -f "$out/lib/node_modules/@qwen-code/qwen-code"
    rm -f "$out/lib/node_modules/@qwen-code/qwen-code-core"

    cp -r packages/cli "$out/lib/node_modules/@qwen-code/qwen-code"
    cp -r packages/core "$out/lib/node_modules/@qwen-code/qwen-code-core"

    mkdir -p "$out/bin"
    ln -s ../lib/node_modules/@qwen-code/qwen-code/dist/index.js "$out/bin/qwen"

    runHook postInstall
  '';

  postInstall = ''
    chmod +x "$out/bin/qwen"
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "qwen-code-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      jq
      nix-prefetch-github
      prefetch-npm-deps
    ];
    text = ''
      latest_version=$(curl -s "https://raw.githubusercontent.com/QwenLM/qwen-code/main/package-lock.json" | jq -r '.version')
      latest_rev=$(curl -s "https://api.github.com/repos/QwenLM/qwen-code/commits/main" | jq -r '.sha')

      src_hash=$(nix-prefetch-github QwenLM qwen-code --rev "$latest_rev" | jq -r '.hash')

      temp_dir=$(mktemp -d)
      curl -s "https://raw.githubusercontent.com/QwenLM/qwen-code/$latest_rev/package-lock.json" > "$temp_dir/package-lock.json"
      npm_deps_hash=$(prefetch-npm-deps "$temp_dir/package-lock.json")
      rm -rf "$temp_dir"

      sed -i "s|version = \".*\";|version = \"$latest_version\";|" "pkgs/qwen-code/default.nix"
      sed -i "s|rev = \".*\";|rev = \"$latest_rev\";|" "pkgs/qwen-code/default.nix"
      sed -i "/src = fetchFromGitHub/,/};/s|hash = \".*\";|hash = \"$src_hash\";|" "pkgs/qwen-code/default.nix"
      sed -i "/npmDeps = fetchNpmDeps/,/};/s|hash = \".*\";|hash = \"$npm_deps_hash\";|" "pkgs/qwen-code/default.nix"
    '';
  });

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/QwenLM/qwen-code";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ donteatoreo ];
    platforms = lib.platforms.all;
    mainProgram = "qwen";
  };
})
