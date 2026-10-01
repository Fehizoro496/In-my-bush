package mg.inmybush.api.common;

import java.util.regex.Pattern;

/** Malagasy mobile numbers, stored in E.164 form (+261XXXXXXXXX). */
public final class PhoneNumbers {

    private static final Pattern E164_MG = Pattern.compile("^\\+261\\d{9}$");

    private PhoneNumbers() {
    }

    /** Accepts "034 12 345 67", "0341234567", "261341234567" or "+261 34 12 345 67". */
    public static String normalize(String raw) {
        if (raw == null) {
            throw new BadRequestException("INVALID_PHONE", "Numéro de téléphone manquant.");
        }
        String digits = raw.replaceAll("[\\s.\\-()]", "");
        String normalized;
        if (digits.startsWith("+261")) {
            normalized = digits;
        } else if (digits.startsWith("261")) {
            normalized = "+" + digits;
        } else if (digits.startsWith("0") && digits.length() == 10) {
            normalized = "+261" + digits.substring(1);
        } else {
            normalized = digits;
        }
        if (!E164_MG.matcher(normalized).matches()) {
            throw new BadRequestException("INVALID_PHONE", "Numéro de téléphone invalide : " + raw);
        }
        return normalized;
    }

    public static boolean looksLikePhone(String value) {
        return value != null && value.replaceAll("[\\s.\\-()+]", "").matches("\\d{9,12}");
    }

    /** "+261341234567" → "+261 34 •• ••• 67". */
    public static String mask(String e164) {
        if (e164 == null || e164.length() < 6) {
            return e164;
        }
        String local = e164.startsWith("+261") ? e164.substring(4) : e164;
        String prefix = local.substring(0, Math.min(2, local.length()));
        String suffix = local.substring(local.length() - 2);
        return "+261 " + prefix + " •• ••• " + suffix;
    }
}
