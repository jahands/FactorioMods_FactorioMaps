from PIL import Image
import multiprocessing as mp
import os, math, sys, time



    
ext = ".jpg"

def work(folder, start, stop, chunk):
    chunksize = 2**(start-stop)
    for k in range(start, stop, -1):
        x = chunksize*chunk[0]
        y = chunksize*chunk[1]
        for i in range(x, x + chunksize, 2):
            if not os.path.exists(folder + str(k-1) + "/" + str(i/2)):
                try:
                    os.makedirs(folder + str(k-1) + "/" + str(i/2))
                except OSError:
                    pass
                
            for j in range(y, y + chunksize, 2):

                #print(k, i, j)

                coords = [(0,0), (1,0), (0,1), (1,1)]
                paths = ["%s%s/%s/%s%s" % (folder, k, i+coord[0], j+coord[1], ext) for coord in coords]

                if any(os.path.isfile(path) for path in paths):

                    size = 0
                    for path in paths:
                        if (os.path.isfile(path)):
                            size = Image.open(path).size[0]
                            break

                    result = Image.new('RGB', (size, size), (27, 45, 51))

                    for m in range(4):
                        if (os.path.isfile(paths[m])):
                            result.paste(box=(coords[m][0]*size/2, coords[m][1]*size/2), im=Image.open(paths[m]).resize((size/2, size/2), Image.LANCZOS))

                    result.save(folder + str(k-1) + "/" + str(i/2) + "/" + str(j/2) + ext, format='JPEG', subsampling=0, quality=100)     


        chunksize = chunksize / 2

def thread(folder, start, stop, allChunks, queue):
    #print(start, stop, chunks)
    try:
        first = True
        while not queue.empty():
            n = queue.get(True)
            chunk = allChunks[n]
            if first:
                first = False
            else:
                print("    (%s, %s)" % chunk)
            work(folder, start, stop, chunk)
    except mp.queues.Empty:
        pass

        


            

if __name__ == '__main__':



    subname = (sys.argv[1] if len(sys.argv) > 1 else "Day")
    toppath = (sys.argv[2] if len(sys.argv) > 2 else "../../script-output/FactorioMaps/Test") + "/"
    folder = os.path.join(toppath, "Images/", subname + "/")
    datapath = os.path.join(toppath, "zoomData.txt")
    maxthreads = mp.cpu_count()

    print(folder)

    waitfilename = os.path.join(toppath, "done-" + subname + ".txt")
    if not os.path.exists(waitfilename):
        print("waiting for done-" + subname + ".txt")
        while not os.path.exists(waitfilename):
            time.sleep(1)
    
    with open(datapath, "r") as data:
        first = data.readline().rstrip('\n').split(" ")
        start = int(first[1])
        stop = int(first[0])
        allBigChunks = []
        for line in data:
            pos = map(int, line.rstrip('\n').split(" "))
            allBigChunks.append(pos)

    threadsplit = 0
    while 4**threadsplit * len(allBigChunks) < maxthreads:
        threadsplit = threadsplit + 1
    threadsplit = min(start - stop, threadsplit + 4)
    allChunks = []
    queue = mp.Queue()
    for pos in allBigChunks:
        for i in range(2**threadsplit):
            for j in range(2**threadsplit):
                allChunks.append((pos[0]*(2**threadsplit) + i, pos[1]*(2**threadsplit) + j))
                queue.put(queue.qsize())

    threads = min(len(allChunks), maxthreads)
    processes = []
    
    print("%s-%s (total: %s):" % (start, stop + threadsplit, len(allChunks)))
    for t in range(0, threads):
        p = mp.Process(target=thread, args=(folder, start, stop + threadsplit, allChunks, queue))
        p.start()
        processes.append(p)
        print("    (%s, %s)" % allChunks[t])
    
    for p in processes:
        p.join()
        

    
    print("%s-%s (total: %s):" % (stop + threadsplit, stop, len(allBigChunks)))
    processes = []
    i = len(allBigChunks) - 1
    for chunk in allBigChunks:
        p = mp.Process(target=work, args=(folder, stop + threadsplit, stop, chunk))
        print("    (%s, %s)" % (chunk[0], chunk[1]))
        i = i - 1
        p.start()
    for p in processes:
        p.join()
    
    #os.remove(folder + "../zoomData.txt")
