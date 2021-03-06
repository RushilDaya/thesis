function color = getVPixxMarkerColor(marker)
    colorsForBits = [ [0, 64, 0];...
                      [0, 16, 0];...
                      [0, 4, 0]; ...
                      [0, 1, 0]; ...
                      [64, 0, 0]; ...
                      [16, 0, 0]; ...
                      [4, 0, 0]; ...
                      [1, 0, 0]];
    binaryMarker = bitget(marker, 1:1:8);
    color = sum(repmat(binaryMarker', 1,3) .* colorsForBits, 1);
end