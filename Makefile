docs.generate:
	aws s3 cp ./doc/ s3://civilcode-ex/ --recursive --acl public-read

docs.open:
	open http://civilcode-ex.s3-website-us-east-1.amazonaws.com
