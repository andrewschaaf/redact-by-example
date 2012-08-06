#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


typedef struct _RGB {
	unsigned char r, g, b;
} RGB;


void fatal_error(NSString *msg) {
    NSLog(@"%@", msg);
    exit(1);
}

NSBitmapImageRep* loadImageRep(const char *path) {
    NSString *pathString = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:pathString];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[img TIFFRepresentation]];
    if ([rep samplesPerPixel] != 3) {
        fatal_error(@"only RGB supported so far");
    }
    if ([rep bitsPerPixel] != 24) {
        fatal_error(@"only 24-bit pixels supported so far");
    }
    return rep;
}


int main(int argc, const char * argv[]) {
    if (argc != (1 + 3 + 3)) {
        fatal_error(@"invalid args");
    }
    NSBitmapImageRep *exampleRep = loadImageRep(argv[1]);
    NSBitmapImageRep *targetRep = loadImageRep(argv[2]);
    NSString *destPath = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
    RGB redactionPixel;
    redactionPixel.r = atoi(argv[4]);
    redactionPixel.g = atoi(argv[5]);
    redactionPixel.b = atoi(argv[6]);
    
    long w = (long)[exampleRep pixelsWide];
    long h = (long)[exampleRep pixelsHigh];
    long i;
    if ((w != [exampleRep pixelsWide]) || (h != [exampleRep pixelsHigh])) {
        fatal_error(@"Dimensions don't match.");
    }
    
    RGB *examplePixels = (RGB *)[exampleRep bitmapData];
    RGB *targetPixels = (RGB *)[targetRep bitmapData];
    RGB pixel;
    for (long y = 0; y < h; y++) {
        for (long x = 0; x < w; x++) {
            i = (y * w) + x;
            pixel = examplePixels[i];
            if (
                    (pixel.r == redactionPixel.r) &&
                    (pixel.g == redactionPixel.g) &&
                    (pixel.b == redactionPixel.b)) {
                targetPixels[i] = redactionPixel;
            }
        }
    }
    
    NSData *png = [targetRep representationUsingType:NSPNGFileType properties:nil];
    [png writeToFile:destPath atomically:YES];
    
    return 0;
}
