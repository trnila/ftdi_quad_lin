import pytest
import os
import can
import select
from plin.device import PLIN, PLINMessage
from plin.enums import PLINMode, PLINMessageType


def read_from_peak(plin: PLIN) -> PLINMessage:
    os.set_blocking(plin.fd, False)

    while True:
        ready, _, _ = select.select([plin.fd], [], [], 1.0)
        if not ready:
            raise TimeoutError("No data received on PLIN fd within 1 second")

        frame = os.read(plin.fd, PLINMessage.buffer_length)
        frame = PLINMessage.from_buffer_copy(frame)
        print(frame)

        if frame.type != PLINMessageType.SLEEP:
            return frame


@pytest.mark.parametrize("chan", [0, 1, 2, 3])
def test_ftdi_sends_to_peak(chan):
    plin = PLIN(interface=f"/dev/plin{chan}")
    plin.start(mode=PLINMode.SLAVE, baudrate=19200)
    plin.set_id_filter(bytearray([0xFF] * 8))

    data = [chan, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77]
    frame_id = 0x8

    # Send a master message from FTDI Quad Lin
    with can.Bus(interface="socketcan", channel=f"sllin{chan}") as bus:
        msg = can.Message(arbitration_id=frame_id, data=data, is_extended_id=False)
        bus.send(msg)

    # Read the message from the PLIN device
    frame = read_from_peak(plin)
    print(frame)

    assert frame.id == frame_id
    assert frame.len == len(data)
    assert list(frame.data)[: frame.len] == data
