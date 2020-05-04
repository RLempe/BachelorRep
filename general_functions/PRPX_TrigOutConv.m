function [TrigOut] = PRPX_TrigOutConv(TrigIn)
%PRPX_TRIGOUTCONV Function to convert trigger numbers for ProPixx and Biosemi
%   - Datapixx module can send out 25 bit TTL numbers
%   - BioSemi uses 8bit representation of triggers (0 to 255)
%   - only input of specific pins is read in --> conversion is required
%   - function requires trigger number (TrigIn) to be converted (TrigOut)

%   - conversion table:
%       - BioSemi Number    |   ProPixxNumber
%                       0   |   0
%                   1   2^0 |   2^2
%                   2   2^1 |   2^4
%                   4   2^2 |   2^6
%                   8   2^3 |   2^8
%                   16  2^4 |   2^10
%                   32  2^5 |   2^12
%                   64  2^6 |   2^14
%                   128 2^7 |   2^16


% first binarize TrigerNumber
TrigIn_bin = dec2bin(TrigIn);

% fill up binary number with 0 to compensate for pin conversion (BioSemi
% only considers only pins 3:2:17
TrigIn_bin_ext = [sprintf('%c0',TrigIn_bin) '0'];

% finally convert back to decimal number
TrigOut = bin2dec(TrigIn_bin_ext);
end

