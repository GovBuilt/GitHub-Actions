function Program {
    param(
        [string]
        $EdgeVersion
    )

    bash -c "curl -O https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${EdgeLinuxVersion}_amd64.deb"
    bash -c "sudo apt install ./microsoft-edge-stable_${EdgeLinuxVersion}_amd64.deb"
}

Program $args[0]
