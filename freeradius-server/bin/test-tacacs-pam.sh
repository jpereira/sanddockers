#!/bin/bash -fx

echo hello | pamtester -v -I tty=tapioca/0 -I rhost=localhost test bob authenticate acct_mgmt open_session close_session
