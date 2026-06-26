#!/bin/bash

PLAYER="spotify"

CURRENT=$(playerctl --player=$PLAYER loop)
case "$CURRENT" in
    "None")
        playerctl --player=$PLAYER loop playlist
        ;;
    "Playlist")
        playerctl --player=$PLAYER loop track
        ;;
    "Track")
        playerctl --player=$PLAYER loop none
        ;;
    *)
        playerctl --player=$PLAYER loop none
        ;;
esac

