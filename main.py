import math
import time
import multiprocessing as mp
import subprocess
import cv2
import numpy
import mss
import csv
from pynput import mouse


def time_since_start():
    return (time.time() - time_since_start.start_time)*1000


time_since_start.start_time = time.time()


def on_move(x, y):
    print('Pointer moved to {0}'.format(
        (x, y)))


def on_click(x, y, button, pressed, queue_csv):
    print('{0} at {1}'.format(
        'Pressed' if pressed else 'Released',
        (x, y)))
    queue_csv.put([str(time_since_start()), str(x), str(y), button, 'Pressed' if pressed else 'Released'])


def on_scroll(x, y, dx, dy, queue_csv):
    print('Scrolled {0} at {1}'.format(
        'down' if dy < 0 else 'up',
        (x, y)))
    queue_csv.put([str(time_since_start()), str(x), str(y), '-120' if dy < 0 else '120', 'WM_MOUSEWHEEL'])


def grab(queue: mp.Queue, fps, queue_csv: mp.Queue):
    monitor = {"top": 0, "left": 0, "width": 1920, "height": 1080}
    number_frames = 0
    start_time = time_since_start()
    former_ticks = 0
    with mss.mss() as sct:
        while "Screen capturing":

            time_elapsed = time_since_start() - start_time

            ticks = math.floor(time_elapsed / ((1/fps)*1000)) - former_ticks
            if ticks >= 1:
                if ticks > 1:
                    print("Frame skipped")
                    for i in range(ticks-1):
                        queue_csv.put([str(time_since_start()), "Frame skipped", ""])
                former_ticks += ticks
                if number_frames == 0:
                    print("start_process:" + str(time_since_start()))
                    queue_csv.put([str(time_since_start()), "StartMedia"])
                img = numpy.array(sct.grab(monitor))
                img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)

                for i in range(ticks):
                    queue.put(img)
                    print(time_elapsed)
                    number_frames += 1
                    print(number_frames)


def record(queue: mp.Queue, fps, queue_csv: mp.Queue):

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    vid = cv2.VideoWriter('output.mp4', fourcc, fps, (1920//2, 1080//2))
    file = open("test.csv", "w", newline="")
    writer = csv.writer(file)
    writer.writerow(["Timestamp", "Source", "Gaze.X", "Gaze.Y", "Data", "Comment"])
    while "Recording":
        if not queue.empty():
            img = queue.get()
            if img is None:
                break
            img = cv2.resize(img, (1920//2, 1080//2))
            vid.write(img)
        if not queue_csv.empty():
            writer.writerow(queue_csv.get())
    file.close()


if __name__ == '__main__':
    fps = 30.0
    queue: mp.Queue = mp.Queue()
    queue_csv: mp.Queue = mp.Queue()

    listener = mouse.Listener(
        on_move=lambda x, y: on_move(x, y),
        on_click=lambda x, y, button, pressed: on_click(x, y, button, pressed, queue_csv),
        on_scroll=lambda x, y, dx, dy: on_scroll(x, y, dx, dy, queue_csv))
    listener.start()
    grabbing = mp.Process(target=grab, args=(queue, fps, queue_csv))
    recording = mp.Process(target=record, args=(queue, fps, queue_csv))
    grabbing.start()
    recording.start()
    start = time_since_start()
    print("start:" + str(start))
    # browser = subprocess.Popen([r"C:\Program Files\Google\Chrome\Application\chrome.exe", r"www.perdu.com"], start_new_session=True)
    cv2.waitKey(5000)
    end = time_since_start()
    subprocess.Popen([r"taskkill", r"/IM", r"firefox.exe"], shell=True)
    print("end:" + str(end - start))
    queue.put(None)
    queue.close()
    queue.join_thread()
    listener.stop()
    queue_csv.close()
    queue_csv.cancel_join_thread()
    grabbing.terminate()
    print("OVER")
