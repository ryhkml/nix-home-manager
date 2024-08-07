self: super:

{
  vscodium = super.vscodium.overrideAttrs (oldAttrs: {
    postInstall = oldAttrs.postInstall or "" + ''
      # Add options by default to avoid VSCodium crash
      wrapProgram $out/bin/codium --add-flags "--disable-extensions"
      # Edit mimetype .desktop configuration
      if [ -f $out/share/applications/codium.desktop ]; then
        sed -i "/MimeType=/d" $out/share/applications/codium.desktop
        sed -i "/Name=VSCodium/a MimeType=text/plain;application/json;application/xml;application/xhtml+xml;text/markdown;inode/directory" $out/share/applications/codium.desktop
      fi
    '';
  });
}