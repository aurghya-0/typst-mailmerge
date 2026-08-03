// tests/test_all.typ - Unit Test Suite for Typst Mail Merge Package

#import "../lib.typ": (
  mail-merge,
  mail-merge-labels,
  mail-merge-stats,
  mail-merge-preview,
  presets,
  read-csv-data,
  field,
  fmt-field,
  bind-field,
  join-fields,
  if-field,
  is-empty,
  is-non-empty,
  record-index,
  record-total,
  is-first-record,
  is-last-record
)

#set page(paper: "us-letter", margin: 1in)

= Typst Mail Merge Package Unit Tests

// Test 1: Field getter & normalizer
#let test-rec = (
  "First_Name": "Alice",
  "Last Name": "Smith",
  "City": "New York",
  "Empty": ""
)

#assert.eq(field(test-rec, "First Name"), "Alice")
#assert.eq(field(test-rec, "last-name"), "Smith")
#assert.eq(field(test-rec, ("NonExistent", "City")), "New York")
#assert.eq(field(test-rec, "Missing", default: "N/A"), "N/A")
#assert.eq(field(test-rec, "Empty", default: "N/A"), "N/A")
[✔] Test 1: Field getter & smart key lookup passed.

// Test 2: Field formatters & Bound #f("Key") syntax
#assert.eq(fmt-field(test-rec, "First Name", fmt: "upper"), "ALICE")
#assert.eq(fmt-field(test-rec, "Last Name", fmt: "lower"), "smith")
#assert.eq(fmt-field(test-rec, "City", fmt: "title"), "New York")
#assert.eq(fmt-field(test-rec, "Missing", fmt: "upper", default: "NONE"), "NONE")
#assert.eq(fmt-field(("price": "50"), "price", fmt: "currency"), "$50")

// Test bound #f("Key") syntax
#let f = bind-field(test-rec)
#assert.eq(f("First Name"), "Alice")
#assert.eq(f("Last Name", fmt: "upper"), "SMITH")
#assert.eq(f("City", fmt: "title"), "New York")
[✔] Test 2: Field formatters & bound #f("Key") syntax passed.

// Test 3: Join fields & conditional helpers
#let addr-rec = ("Addr1": "100 Main St", "Addr2": "", "City": "Boston", "State": "MA")
#assert.eq(join-fields(addr-rec, ("Addr1", "Addr2", "City", "State")), "100 Main St, Boston, MA")
#assert.eq(is-empty(addr-rec, "Addr2"), true)
#assert.eq(is-non-empty(addr-rec, "Addr1"), true)
[✔] Test 3: Join-fields & conditional checks passed.

// Test 4: Array-of-arrays conversion
#let arr-data = (
  ("Name", "Score"),
  ("Bob", "95"),
  ("Alice", "90")
)
#let parsed = read-csv-data(arr-data)
#assert.eq(parsed.len(), 2)
#assert.eq(field(parsed.at(0), "Name"), "Bob")
#assert.eq(field(parsed.at(1), "Score"), "90")
[✔] Test 4: Array-of-arrays CSV data parsing passed.

// Test 5: Dataset statistics
#let stats = mail-merge-stats(arr-data)
#assert.eq(stats.total-records, 2)
#assert.eq(stats.fields, ("Name", "Score"))
[✔] Test 5: Dataset statistics inspection passed.

// Test 6: Mail merge pagination & empty handling
#mail-merge(
  arr-data,
  start: 2,
  limit: 1,
  pagebreak: false,
  r => [
    #assert.eq(field(r, "Name"), "Alice")
    #assert.eq(record-index(r), 1)
    #assert.eq(record-total(r), 1)
    [✔] Test 6: Mail merge pagination & metadata passed.
  ]
)

// Test 7: Label Grid Presets check
#mail-merge-labels(
  arr-data,
  preset: presets.avery-5160,
  show-cut-lines: true,
  r => [
    #field(r, "Name")
  ]
)
[✔] Test 7: Label grid layout rendering passed.

#v(2em)
#text(size: 14pt, weight: "bold", fill: rgb("#276749"))[ALL UNIT TESTS PASSED SUCCESSFULLY!]
