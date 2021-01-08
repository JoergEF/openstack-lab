new:
	git pull
	vagrant up

clean:
	vagrant destroy -f
	wait $!
	rm -rf .vagrant
	rm ssh_*
