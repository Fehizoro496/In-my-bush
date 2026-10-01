package mg.inmybush.api.common;

import java.text.Normalizer;
import java.util.Locale;

/** URL slugs from French labels: "Tomates cœur de bœuf" → "tomates-coeur-de-boeuf". */
public final class Slugs {

    private Slugs() {
    }

    public static String slugify(String input) {
        if (input == null) {
            return "item";
        }
        String s = input.toLowerCase(Locale.ROOT).replace("œ", "oe").replace("æ", "ae");
        s = Normalizer.normalize(s, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        s = s.replaceAll("[^a-z0-9]+", "-").replaceAll("(^-+|-+$)", "");
        if (s.length() > 120) {
            s = s.substring(0, 120).replaceAll("-+$", "");
        }
        return s.isEmpty() ? "item" : s;
    }
}
