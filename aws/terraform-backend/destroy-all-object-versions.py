#!/usr/bin/env python
import boto3
import sys

s3 = boto3.resource('s3')
bucket = s3.Bucket(sys.argv[1])
bucket.object_versions.all().delete()
