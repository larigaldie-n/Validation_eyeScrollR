import math
import time
import multiprocessing as mp
import subprocess
import cv2
import numpy
import mss
import csv
import pylink
import sys
import os
from pynput import mouse
from pynput import keyboard


def time_since_start():
    return (time.time() - time_since_start.start_time)*1000


time_since_start.start_time = time.time()


def on_release(key, queue_csv):
    time_keyboard = time_since_start()
    print('{0} released'.format(key))
    queue_csv.put([time_keyboard, "Keyboard",
                   f"Key: {key} (Released)"])
    if str(key) == "'s'" or str(key) == "'S'":
        # Stop listener
        return False


def on_click(x, y, button, pressed, queue_csv):
    time_mouse = time_since_start()
    print(f'{"Pressed" if pressed else "Released"} time {time_mouse}')
    queue_csv.put([time_mouse, "Mouse",
                   f"X:{x}; Y:{y}; MouseEvent:{button}{('.Pressed' if pressed else '.Released')}"])


def on_scroll(x, y, dx, dy, queue_csv):
    time_mouse = time_since_start()
    print(f'Scrolled {"down" if dy < 0 else "up"} at {time_since_start()}')
    queue_csv.put([time_mouse, "Mouse",
                   f"X:{x}; Y:{y}; MouseEvent:WM_MOUSEWHEEL; ScrollDelta:{'-120' if dy < 0 else '120'}"])


def grab(queue: mp.Queue, fps, queue_csv: mp.Queue, start_time, queue_termination: mp.Queue,
         monitor_width, monitor_height):
    monitor = {"top": 0, "left": 0, "width": monitor_width, "height": monitor_height}
    number_frames = 0
    with mss.mss() as sct:
        start_time_process = (time.time() - start_time)*1000
        while "Screen capturing":
            time_elapsed = (time.time() - start_time)*1000 - start_time_process

            ticks = math.floor(time_elapsed / ((1/fps)*1000)) - number_frames
            if ticks >= 1:
                img = numpy.array(sct.grab(monitor))
                time_grabbed = (time.time() - start_time)*1000
                if number_frames == 0:
                    print(f"start_process: {time_grabbed}")
                    queue_csv.put([time_grabbed, "Video recorder",
                                   "Started recording (first frame)"])
                for i in range(ticks):
                    print(f"Frame number {number_frames + i} at {time_grabbed}")
                    queue_csv.put([time_grabbed, "Video recorder",
                                   f"Frame {(number_frames + i)}{' (skipped)' if i > 0 else ''}"])
                queue.put((img, ticks))
                number_frames += ticks
            if not queue_termination.empty():
                queue.put(None)
                break


def record(queue: mp.Queue, fps, queue_csv: mp.Queue, monitor_width, monitor_height, file_name):

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    vid = cv2.VideoWriter(f'{file_name}.mp4', fourcc, fps, (monitor_width, monitor_height))
    # vid = cv2.VideoWriter('output.mp4', fourcc, fps, (monitor_width//2, monitor_height//2))
    file = open(f'{file_name}.csv', "w", newline="")
    writer = csv.writer(file)
    writer.writerow(["Timestamp", "Source", "Data"])
    while "Recording":
        if not queue.empty():
            img_queue_element = queue.get()
            if img_queue_element is None:
                break
            img = img_queue_element[0]
            img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
            # img = cv2.resize(img, (monitor_width//2, monitor_height//2))
            for i in range(img_queue_element[1]):
                vid.write(img)
        if not queue_csv.empty():
            writer.writerow(queue_csv.get())
    file.close()


if __name__ == '__main__':

    no_eye_tracker_debug = int(input("Debug mode (0=no, 1=yes): "))
    participant_stage = input("Participant stage: ")
    monitor_width = int(input("Resolution X: "))
    monitor_height = int(input("Resolution Y: "))
    file_name = f'S{participant_stage}_{monitor_width}_{monitor_height}.edf'
    if not os.path.exists(participant_stage):
        os.makedirs(participant_stage)
    local_file_name = os.path.join(participant_stage, file_name)
    participant_stage = int(participant_stage)

    if participant_stage == 1:
        website = r"https://larigaldie-n.github.io/eyeScrollR/test_no_fixed.html"
    elif participant_stage == 2:
        website = r"https://larigaldie-n.github.io/eyeScrollR/test_page.html"
    elif participant_stage == 3:
        website = r"https://psychopy.org/"
    elif participant_stage == 4:
        website = r"https://osf.io/"
    else:
        print('ERROR: invalid stage')
        sys.exit()

    fps = 30.0
    queue: mp.Queue = mp.Queue()
    queue_csv: mp.Queue = mp.Queue()
    queue_termination: mp.Queue = mp.Queue()

    mouse_listener = mouse.Listener(
        on_click=lambda x, y, button, pressed: on_click(x, y, button, pressed, queue_csv),
        on_scroll=lambda x, y, dx, dy: on_scroll(x, y, dx, dy, queue_csv))
    mouse_listener.start()
    grabbing = mp.Process(target=grab, args=(queue, fps, queue_csv, time_since_start.start_time,
                                             queue_termination, monitor_width, monitor_height))
    recording = mp.Process(target=record, args=(queue, fps, queue_csv, monitor_width, monitor_height,
                                                f'S{participant_stage}_{monitor_width}_{monitor_height}'))
    grabbing.start()
    recording.start()
    start = time_since_start()
    print(f"start: {start}")
    browser = subprocess.Popen([r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                                website],
                               start_new_session=True)
    if no_eye_tracker_debug == 1:
        with keyboard.Listener(on_release=lambda key: on_release(key, queue_csv)) as keyboard_listener:
            keyboard_listener.join()
    else:
        with keyboard.Listener(on_release=lambda key: on_release(key, queue_csv)) as keyboard_listener:
            try:
                eye_tracker = pylink.EyeLink("100.1.1.1")
            except RuntimeError as error:
                print('ERROR:', error)
                sys.exit()
            pylink.openGraphics((0, 0), 32)

            eye_tracker.openDataFile(file_name)
            eye_tracker.setOfflineMode()
            eye_tracker.sendCommand("sample_rate 1000")
            eye_tracker.sendCommand(f'screen_pixel_coords 0 0 {monitor_width - 1} {monitor_height - 1}')
            eye_tracker.sendMessage(f'DISPLAY_COORDS 0 0 {monitor_width - 1} {monitor_height - 1}')
            pylink.setCalibrationColors((0, 0, 0), (128, 128, 128))
            pylink.setTargetSize(int(monitor_width / 70.0), int(monitor_width / 300.0))
            eye_tracker.doTrackerSetup()
            eye_tracker.setOfflineMode()
            pylink.closeGraphics()
            eye_tracker.startRecording(1, 1, 0, 0)
            eye_tracker.sendMessage(f'SYNCTIME')
            queue_csv.put([time_since_start(), "Synchronizer", "SYNCTIME"])
            keyboard_listener.join()
            eye_tracker.stopRecording()
            eye_tracker.setOfflineMode()
            pylink.msecDelay(250)
            eye_tracker.closeDataFile()
            eye_tracker.receiveDataFile(file_name, local_file_name)
            eye_tracker.stopRecording()
            eye_tracker.close()

    subprocess.Popen([r"taskkill", r"/IM", r"chrome.exe"], shell=True)
    print(f"end: {time_since_start() - start}")
    queue_termination.put(None)
    recording.join()
    mouse_listener.stop()
    print("OVER")
