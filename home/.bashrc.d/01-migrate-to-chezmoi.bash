
_download_chezmoi() {
  OS=
  case "$(uname -s)" in
    Linux) OS="linux" ;;
    Darwin) OS="darwin" ;;
    *)
      echo "OS not supported."
      exit 2 ;;
  esac

  ARCH=
  case "$(uname -m)" in
  x86_64 | amd64)
      ARCH="amd64" ;;
  aarch64 | arm64)
      ARCH="arm64" ;;
  *)
      echo "OS architecture not supported."
      exit 2
      ;;
  esac

  mkdir -p "$HOME/bin"
  cd "$HOME/bin" || exit 1
  bin="chezmoi-$OS-$ARCH"
  curl -sSL -o "$bin" "https://github.com/twpayne/chezmoi/releases/download/v2.62.4/$bin"
  shasum -a 256 --check --ignore-missing <<EOF
07910f5c2eb9acb074a7b27833a0534b716ba2317ea9339e6a5ddb580cbc5f60  chezmoi-darwin-amd64
e2e9ee87d47e34f87ac5dee1c582a7e11fa3dd32d51b5b32995ac1f877294b93  chezmoi-darwin-arm64
158aee682cb6765efa19120667c3aaa67842fcaa6118441f149171b9c2eb8eb6  chezmoi-linux-amd64
EOF
  if [[ $? != 0 ]]; then \
      echo Downloaded chezmoi is tainted somehow! sha256sum failed
      rm -f "$bin"
      exit 1
  fi
  mv "$bin" chezmoi
  chmod +x chezmoi
  ./chezmoi init kruton --apply
}

_download_chezmoi

