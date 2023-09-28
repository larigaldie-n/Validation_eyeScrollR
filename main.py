import math
import time
import multiprocessing as mp
import subprocess
import cv2
import numpy
import mss
import csv
import pylink
from pynput import mouse


def time_since_start():
    return (time.time() - time_since_start.start_time)*1000


time_since_start.start_time = time.time()


def on_move(x, y):
    time_mouse = time_since_start()
    print('Pointer moved to {0} time {1}'.format(
        (x, y), time_mouse))


def on_click(x, y, button, pressed, queue_csv):
    time_mouse = time_since_start()
    print(f'{"Pressed" if pressed else "Released"} time {time_mouse}')
    queue_csv.put([time_mouse, "Mouse",
                   f"X:{x}; Y:{y}; MouseEvent:{button}{('.Pressed' if pressed else '.Released')}", "", ""])


def on_scroll(x, y, dx, dy, queue_csv):
    time_mouse = time_since_start()
    print(f'Scrolled {"down" if dy < 0 else "up"} at {time_since_start()}')
    queue_csv.put([time_mouse, "Mouse",
                   f"X:{x}; Y:{y}; MouseEvent:WM_MOUSEWHEEL; ScrollDelta:{'-120' if dy < 0 else '120'}", "", ""])


def grab(queue: mp.Queue, fps, queue_csv: mp.Queue, start_time, queue_termination: mp.Queue):
    monitor = {"top": 0, "left": 0, "width": 2560, "height": 1440}
    number_frames = 0
    with mss.mss() as sct:
        start_time_process = (time.time() - start_time)*1000
        while "Screen capturing":

            time_elapsed = (time.time() - start_time)*1000 - start_time_process

            ticks = math.floor(time_elapsed / ((1/fps)*1000)) - number_frames
            if ticks >= 1:
                img = numpy.array(sct.grab(monitor))
                if number_frames == 0:
                    print(f"start_process: {(time.time() - start_time)*1000}")
                    queue_csv.put([(time.time() - start_time)*1000, "Video recorder",
                                   "Started recording (first frame)", "", ""])
                img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
                queue.put((img, ticks))
                for i in range(ticks):
                    print(f"Frame number {number_frames + i} at {(time.time() - start_time) * 1000}")
                    queue_csv.put([(time.time() - start_time) * 1000, "Video recorder", f"Frame {(number_frames + i)}{' (skipped)' if i > 0 else ''}", "", ""])
                number_frames += ticks
            if not queue_termination.empty():
                queue.put(None)
                break


def record(queue: mp.Queue, fps, queue_csv: mp.Queue):

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    vid = cv2.VideoWriter('output.mp4', fourcc, fps, (2560//2, 1440//2))
    file = open("test.csv", "w", newline="")
    writer = csv.writer(file)
    writer.writerow(["Timestamp", "Source", "Data", "Gaze.X", "Gaze.Y"])
    while "Recording":
        if not queue.empty():
            img_queue_element = queue.get()
            if img_queue_element is None:
                break
            img = img_queue_element[0]
            img = cv2.resize(img, (2560//2, 1440//2))
            for i in range(img_queue_element[1]):
                vid.write(img)
        if not queue_csv.empty():
            writer.writerow(queue_csv.get())
    file.close()


if __name__ == '__main__':
    fps = 30.0
    queue: mp.Queue = mp.Queue()
    queue_csv: mp.Queue = mp.Queue()
    queue_termination: mp.Queue = mp.Queue()

    listener = mouse.Listener(
        on_move=lambda x, y: on_move(x, y),
        on_click=lambda x, y, button, pressed: on_click(x, y, button, pressed, queue_csv),
        on_scroll=lambda x, y, dx, dy: on_scroll(x, y, dx, dy, queue_csv))
    listener.start()
    grabbing = mp.Process(target=grab, args=(queue, fps, queue_csv, time_since_start.start_time, queue_termination))
    recording = mp.Process(target=record, args=(queue, fps, queue_csv))
    grabbing.start()
    recording.start()
    start = time_since_start()
    print(f"start: {start}")
    browser = subprocess.Popen([r"C:\Program Files\Mozilla Firefox\firefox.exe",
                                r"https://larigaldie-n.github.io/eyeScrollR/test_no_fixed.html"],
                               start_new_session=True)
    cv2.waitKey(10000)
    subprocess.Popen([r"taskkill", r"/IM", r"firefox.exe"], shell=True)
    print(f"end: {time_since_start() - start}")
    queue_termination.put(None)
    recording.join()
    listener.stop()
    print("OVER")
