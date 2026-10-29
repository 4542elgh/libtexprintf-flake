# libtexprintf-flake
A Nix flake that packages [`libtexprintf`](https://github.com/bartp5/libtexprintf), a command line tool that renders TeX-style math as UTF-8 text in the terminal.
```
$ utftex '\frac{a}{b} + \sqrt{x^2+y^2}'
```
This flake builds the upstream project from source and exposes it as a Nix package, and a development shell.
## Quick start
```bash
git clone https://github.com/4542elgh/libtexprintf-flake
cd libtexprintf-flake
nix build
./result/bin/utftex '\int_0^\infty e^{-x^2}\,dx'
```
## Installing
### Run without installing
```bash
nix run github:4542elgh/libtexprintf-flake -- '\alpha^2 + \beta^2'
```
### Add to your own flake.nix
#### Step 1: add the input
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    libtexprintf.url = "github:4542elgh/libtexprintf-flake";
  };

  outputs = { self, nixpkgs, libtexprintf, ... }@inputs: { # make sure you pass libtexprintf here
  };
}
```

**Note: reference the package**
The package is available at:
```
inputs.libtexprintf.packages.${system}.default
```
where `system` is a string such as `x86_64-linux`, `aarch64-linux`, `x86_64-darwin` or `aarch64-darwin`. In NixOS and home-manager modules you can get it from `pkgs.stdenv.hostPlatform.system` (or `pkgs.system` on older nixpkgs).

#### Step 2. Passing input in `flake.nix`
In your system flake (still `flake.nix`, toward bottom), make sure `inputs` is passed to your modules, it should look something like this:
```nix
{
  outputs = { self, nixpkgs, libtexprintf, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
```
#### Step 3. `configuration.nix`:
```nix
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.libtexprintf.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```
#### Step 4. Rebuild:
```bash
sudo nixos-rebuild switch --flake .#myhost
```
### home-manager
If home-manager is used as a standalone flake configuration:
```nix
{
  outputs = { self, nixpkgs, home-manager, libtexprintf, ... }@inputs: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home.nix ];
    };
  };
}
```
Then in `home.nix`:
```nix
{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.libtexprintf.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```
Apply:
```bash
home-manager switch --flake .#myuser
```
If home-manager is used as a NixOS module, set `home-manager.extraSpecialArgs = { inherit inputs; };` in your NixOS configuration, and the `home.nix` above works unchanged.
## License
The upstream project, libtexprintf, is licensed under GPL-3.0. See the upstream repository for the full license text.

The Nix packaging in this repository (`flake.nix`) may be used under the same terms as the upstream project unless a separate license file is included.
