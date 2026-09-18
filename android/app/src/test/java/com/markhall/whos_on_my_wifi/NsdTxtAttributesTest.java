package com.markhall.whos_on_my_wifi;

import org.junit.Test;
import java.nio.charset.StandardCharsets;
import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import static org.junit.Assert.*;

public class NsdTxtAttributesTest {
    /** Reproduces the Android EntrySet contract without an Android runtime. */
    private static Map<String, byte[]> noArrayMap(Map<String, byte[]> data) {
        return Collections.unmodifiableMap(new AbstractMap<String, byte[]>() {
            @Override public Set<Entry<String, byte[]>> entrySet() {
                return new AbstractSet<Entry<String, byte[]>>() {
                    @Override public Iterator<Entry<String, byte[]>> iterator() {
                        return data.entrySet().iterator();
                    }
                    @Override public int size() { return data.size(); }
                    @Override public Object[] toArray() { throw new UnsupportedOperationException("Android EntrySet"); }
                    @Override public <T> T[] toArray(T[] target) { throw new UnsupportedOperationException("Android EntrySet"); }
                };
            }
        });
    }

    @Test public void copiesSmallAndroidStyleMapWithoutToArray() {
        // A small map is important: Kotlin take(24) used to copy all its entries.
        Map<String, byte[]> data = new LinkedHashMap<>();
        data.put("name", "Living Room".getBytes(StandardCharsets.UTF_8));
        data.put("model", "Speaker".getBytes(StandardCharsets.UTF_8));
        Map<String, byte[]> frameworkMap = noArrayMap(data);
        assertThrows(UnsupportedOperationException.class, () -> frameworkMap.entrySet().toArray());
        Map<String, String> result = NsdTxtAttributesKt.safeNsdAttributes(() -> frameworkMap);
        assertEquals("Living Room", result.get("name"));
        assertEquals("Speaker", result.get("model"));
        assertTrue(result instanceof LinkedHashMap);
    }

    @Test public void capsEntriesKeysAndDecodedValues() {
        Map<String, byte[]> data = new LinkedHashMap<>();
        String longKey = String.join("", Collections.nCopies(80, "k"));
        String longValue = String.join("", Collections.nCopies(300, "é"));
        data.put(longKey, longValue.getBytes(StandardCharsets.UTF_8));
        for (int i = 1; i < 30; i++) data.put("key" + i, new byte[] {65});
        Map<String, String> result = NsdTxtAttributesKt.safeNsdAttributes(() -> noArrayMap(data));
        assertEquals(24, result.size());
        assertEquals(longValue.substring(0, 256), result.get(longKey.substring(0, 64)));
        assertTrue(result.containsKey("key23"));
        assertFalse(result.containsKey("key24"));
    }

    @Test public void handlesEmptyNullAndMalformedUtf8() {
        Map<String, byte[]> data = new LinkedHashMap<>();
        data.put("empty", new byte[0]);
        data.put("null", null);
        data.put("malformed", new byte[] {(byte) 0xC3, 0x28});
        data.put(null, new byte[] {65});
        Map<String, String> result = NsdTxtAttributesKt.safeNsdAttributes(() -> noArrayMap(data));
        assertEquals("", result.get("empty"));
        assertEquals("", result.get("null"));
        assertEquals("\uFFFD(", result.get("malformed"));
        assertFalse(result.containsKey(null));
    }

    @Test public void retrievalOrIterationFailureReturnsEmptyMetadata() {
        assertTrue(NsdTxtAttributesKt.safeNsdAttributes(() -> {
            throw new IllegalStateException("Framework getter failed");
        }).isEmpty());
        assertTrue(NsdTxtAttributesKt.safeNsdAttributes(() -> new AbstractMap<String, byte[]>() {
            @Override public Set<Entry<String, byte[]>> entrySet() {
                throw new UnsupportedOperationException("Framework entries failed");
            }
        }).isEmpty());
    }
}
