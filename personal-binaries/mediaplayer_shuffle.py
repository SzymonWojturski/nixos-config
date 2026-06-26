#!/usr/bin/env python3
import gi
gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib
from gi.repository.Playerctl import Player
import argparse
import logging
import sys
import signal
import os

logger = logging.getLogger(__name__)

def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    sys.exit(0)


class PlayerManager:
    def __init__(self, selected_player=None, excluded_player=None):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()

        self.manager.connect("name-appeared", self.on_player_appeared)
        self.manager.connect("player-vanished", self.on_player_vanished)

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)

        self.selected_player = selected_player
        self.excluded_player = excluded_player.split(',') if excluded_player else []

        self.init_players()

    def init_players(self):
        for p in self.manager.props.player_names:
            if p.name in self.excluded_player:
                continue
            if self.selected_player and self.selected_player != p.name:
                continue
            self.init_player(p)

    def run(self):
        self.loop.run()

    def init_player(self, p):
        player = Playerctl.Player.new_from_name(p)

        # listen for Shuffle changes
        player.connect("shuffle", self.on_shuffle_changed)

        self.manager.manage_player(player)

        # emit initial shuffle state
        self.write_shuffle_state(player.props.shuffle)

    def get_players(self):
        return self.manager.props.players

    def write_shuffle_state(self, state):
        state = "" if state else "󰒞"
        sys.stdout.write(state + "\n")
        sys.stdout.flush()

    def on_shuffle_changed(self, player, new_status, _=None):
        self.write_shuffle_state(new_status)

    def on_player_appeared(self, _, player):
        if player.name in self.excluded_player:
            return
        if self.selected_player and player.name != self.selected_player:
            return
        self.init_player(player)

    def on_player_vanished(self, _, player):
        if len(self.get_players()) == 0:
            self.write_shuffle_state(False)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded players")
    parser.add_argument("--player")
    parser.add_argument("--enable-logging", action="store_true")
    return parser.parse_args()


def main():
    args = parse_arguments()

    if args.enable_logging:
        logfile = os.path.join(
            os.path.dirname(os.path.realpath(__file__)),
            "media-player.log"
        )
        logging.basicConfig(
            filename=logfile,
            level=logging.DEBUG,
            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s"
        )

    logger.setLevel(max((3 - args.verbose) * 10, 0))

    player = PlayerManager(args.player, args.exclude)
    player.run()


if __name__ == "__main__":
    main()
