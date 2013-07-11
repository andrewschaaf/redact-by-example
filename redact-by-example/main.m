#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


void fatal_error(NSString *msg) {
    NSLog(@"%@", msg);
    exit(1);
}

NSBitmapImageRep* loadImageRep(const char *path) {
    NSString *pathString = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:pathString];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[img TIFFRepresentation]];
    return rep;
}

int bytesPerPixelWithoutAlphaChannel(long bytesPerPixel) {
    if (bytesPerPixel == 2) {
        return 1;
    } else if (bytesPerPixel == 4) {
        return 3;
    } else {
        return (int)bytesPerPixel;
    }
}

int main(int argc, const char * argv[]) {
    if (argc != (1 + 3 + 3)) {
        fatal_error(@"invalid args");
    }
    NSBitmapImageRep *exampleRep = loadImageRep(argv[1]);
    NSBitmapImageRep *targetRep = loadImageRep(argv[2]);
    NSString *destPath = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
    unsigned char redactedPixel[3];
    redactedPixel[0] = atoi(argv[4]);
    redactedPixel[1] = atoi(argv[5]);
    redactedPixel[2] = atoi(argv[6]);

    long w = (long)[exampleRep pixelsWide];
    long h = (long)[exampleRep pixelsHigh];
    long i, j, redact;
    if ((w != [targetRep pixelsWide]) || (h != [targetRep pixelsHigh])) {
        fatal_error(@"Dimensions don't match.");
    }

    unsigned char *examplePixels = [exampleRep bitmapData];
    unsigned char *targetPixels = [targetRep bitmapData];
    int exampleBpp = [exampleRep bitsPerPixel] / 8;
    int targetBpp = [targetRep bitsPerPixel] / 8;
    int exampleBppWithoutAlpha = bytesPerPixelWithoutAlphaChannel(exampleBpp);
    int targetBppWithoutAlpha = bytesPerPixelWithoutAlphaChannel(targetBpp);

    for (long y = 0; y < h; y++) {
        for (long x = 0; x < w; x++) {
            i = (y * w) + x;
            redact = 1;
            for (j = 0; j < exampleBppWithoutAlpha; j++) {
                if (redactedPixel[j] != examplePixels[(i * exampleBpp) + j]) {
                    redact = 0;
                }
            }
            if (redact) {
                for (j = 0; j < targetBppWithoutAlpha; j++) {
                    targetPixels[(i * targetBpp) + j] = redactedPixel[j];
                }
            }
        }
    }

    NSData *png = [targetRep representationUsingType:NSPNGFileType properties:nil];
    [png writeToFile:destPath atomically:YES];

    return 0;
}
