Suppose that a pixel has the color (R, G, B) if and only if it's been redacted.

Suppose you want the same redactions that were applied to EXAMPLE to be applied to SRC, with the resulting image saved at DEST.

    redact-by-example EXAMPLE SRC DEST R G B

Note: R, G, B `\in` {0, ..., 255}

Note: DEST is always written as a PNG
