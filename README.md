# dotfiles

## installation(macos)

1. Install [Determinate Nix](https://github.com/DeterminateSystems/nix-installer)

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```

2. Clone this repository
   
```bash
git clone kaito4681/dotfiles
cd dotfiles
```

3. Apply configuration
   
```bash
nix run home-manager -- switch --flake .#kaito -b backup
```