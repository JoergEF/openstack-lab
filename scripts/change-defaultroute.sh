#!/usr/bin/env bash
ip route replace default via 192.168.50.253
ip route del default via 10.0.2.2
