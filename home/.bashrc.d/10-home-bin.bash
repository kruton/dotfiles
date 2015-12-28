#!/usr/bin/env bash

# Only add home if it's not already added.

case ":$PATH:" in
  *:$HOME/bin:*) ;;
  *) export PATH=$HOME/bin:$PATH ;;
esac
