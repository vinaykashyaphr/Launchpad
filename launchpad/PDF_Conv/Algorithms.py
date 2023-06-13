import operator


def sorting(data, positions, reverse):
    try:
        zipper = zip(positions, reverse)
        for (pos, rev) in zipper:
            data.sort(key=operator.itemgetter(pos), reverse=rev)
    except TypeError:
        data.sort(key=operator.itemgetter(positions), reverse=reverse)
