file=$(cat /tmp/extra-repos)

for repo in $file; do
	echo "Enabling Copr repository: $repo"
	if ! dnf -y copr enable "$repo"; then
		echo "Error: Failed to enable repository: $repo" >&2
		exit 1
	fi
done

dnf -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release{,-extras}
dnf clean all
