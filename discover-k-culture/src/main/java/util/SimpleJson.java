package util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class SimpleJson {

    private SimpleJson() {
    }


    public static String string(
        String json,
        String key
    ) {

        if (
            json == null
            || key == null
        ) {
            return null;
        }


        Pattern pattern =
            Pattern.compile(
                "\""
                + Pattern.quote(key)
                + "\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\""
            );


        Matcher matcher =
            pattern.matcher(json);


        if (!matcher.find()) {
            return null;
        }


        return unescape(
            matcher.group(1)
        );
    }


    public static String number(
        String json,
        String key
    ) {

        if (
            json == null
            || key == null
        ) {
            return null;
        }


        Pattern pattern =
            Pattern.compile(
                "\""
                + Pattern.quote(key)
                + "\"\\s*:\\s*([0-9]+)"
            );


        Matcher matcher =
            pattern.matcher(json);


        return matcher.find()
            ? matcher.group(1)
            : null;
    }


    private static String unescape(
        String value
    ) {

        StringBuilder out =
            new StringBuilder();


        for (
            int i = 0;
            i < value.length();
            i++
        ) {

            char c =
                value.charAt(i);


            if (
                c != '\\'
                || i + 1 >= value.length()
            ) {
                out.append(c);
                continue;
            }


            char n =
                value.charAt(++i);


            switch (n) {

                case '"':
                    out.append('"');
                    break;

                case '\\':
                    out.append('\\');
                    break;

                case '/':
                    out.append('/');
                    break;

                case 'b':
                    out.append('\b');
                    break;

                case 'f':
                    out.append('\f');
                    break;

                case 'n':
                    out.append('\n');
                    break;

                case 'r':
                    out.append('\r');
                    break;

                case 't':
                    out.append('\t');
                    break;

                case 'u':

                    if (i + 4 < value.length()) {

                        String hex =
                            value.substring(
                                i + 1,
                                i + 5
                            );

                        try {
                            out.append(
                                (char)
                                Integer.parseInt(
                                    hex,
                                    16
                                )
                            );

                            i += 4;

                        } catch (
                            NumberFormatException e
                        ) {
                            out.append("\\u")
                               .append(hex);

                            i += 4;
                        }
                    }

                    break;

                default:
                    out.append(n);
            }
        }


        return out.toString();
    }
}
