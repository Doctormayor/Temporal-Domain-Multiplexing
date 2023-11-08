function curvedistance = signalseparation6g(ng1, ng2,examplecurve, coeffs)

% coeffs(coeffs<0)=0;
% coeffs(coeffs>1)=1;

G1_coeff = coeffs(1);
G2_coeff = coeffs(2);

% G6_coeff = 1 - coeffs(1) - coeffs(2);


examplecurve = examplecurve / max(examplecurve);

combined_curve =G1_coeff * ng1 + G2_coeff * ng2;

curve_difference = abs(combined_curve - examplecurve);
curvedistance = sqrt(mean(curve_difference.^2));