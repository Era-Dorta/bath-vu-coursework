function [ outI ] = myconv( I, kernel )
    kernel = flipud(fliplr(kernel));
    
    kWidth = round(size(kernel, 1) / 2);
    kHeight = round(size(kernel, 2) / 2);
    extraW = 0;
    extraH = 0;
    
    
    if mod(size(kernel,1), 2) == 0
        extraW = 1;
    end
    
    if mod(size(kernel,2), 2) == 0
        extraH = 1;
    end
    
    subI = 1;
    subJ = 1;
    for i=kWidth:size(I,1) - kWidth + 1 - extraW
        for j=kHeight:size(I,2) - kHeight + 1 - extraH
            outI(subI,subJ) = sum(sum(I([i - kWidth + 1:i + kWidth - 1 + extraW],...
                [j - kHeight + 1:j + kHeight - 1 + extraH]) .* kernel));
            subJ = subJ + 1;
        end
        subI = subI + 1;
        subJ = 1;
    end
end

