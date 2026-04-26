## Detective Notebook - Story log and case tracking
extends Node

signal page_added(case_id: String, page: Dictionary)
signal case_solved(case_id: String, ending: String)

class CasePage:
	var id: String
	var title: String
	var content: String
	var timestamp: int
	var category: String  # clue, witness, theory, event
	var evidence_links: Array[String] = []
	
	func _init(p_id: String, p_title: String, p_content: String, p_category: String) -> void:
		id = p_id
		title = p_title
		content = p_content
		category = p_category
		timestamp = Time.get_ticks_msec()

var _case_log: Dictionary = {}  # case_id -> Array of CasePages
var _current_case: String = "burari_deaths"
var _save_path = "user://detective_notes.json"

func _ready() -> void:
	load_case_log()

## Add entry to the detective notebook
func add_page(case_id: String, title: String, content: String, category: String = "event") -> void:
	if case_id not in _case_log:
		_case_log[case_id] = []
	
	var page = CasePage.new(case_id + "_" + title.to_lower(), title, content, category)
	_case_log[case_id].append({
		"id": page.id,
		"title": page.title,
		"content": page.content,
		"timestamp": page.timestamp,
		"category": page.category
	})
	
	print("📝 Case Note: %s - %s" % [title, content.substr(0, 50)])
	page_added.emit(case_id, _case_log[case_id][-1])
	save_case_log()

## Record a clue examination
func record_clue_examination(clue_id: String, clue_name: String, observations: String) -> void:
	var content = "Evidence: %s\n\nObservations:\n%s" % [clue_name, observations]
	add_page(_current_case, "Examined: %s" % clue_name, content, "clue")

## Record witness testimony
func record_witness(witness_name: String, testimony: String) -> void:
	var content = "%s stated:\n\n\"%s\"" % [witness_name, testimony]
	add_page(_current_case, "Witness: %s" % witness_name, content, "witness")

## Record detective theory
func record_theory(theory_name: String, evidence_supporting: Array[String], evidence_against: Array[String]) -> void:
	var content = "Theory: %s\n\n" % theory_name
	content += "Supporting Evidence:\n"
	for evidence in evidence_supporting:
		content += "• %s\n" % evidence
	
	content += "\nCountering Evidence:\n"
	for evidence in evidence_against:
		content += "• %s\n" % evidence
	
	add_page(_current_case, theory_name, content, "theory")

## Mark case as solved with final ending
func solve_case(case_id: String, ending_choice: String) -> void:
	var ending_text = ""
	match ending_choice:
		"close_case":
			ending_text = "Case Closed: Determined to be mass murder-suicide. Evidence inconclusive for extended investigation."
		"dig_deeper":
			ending_text = "Case Escalated: Continuing investigation into potential cult involvement and outside manipulation."
		"hunt_handler":
			ending_text = "Active Pursuit: Handler believed to be involved. Investigation continues with outside agencies."
	
	add_page(case_id, "CASE CONCLUSION", ending_text, "event")
	case_solved.emit(case_id, ending_choice)
	save_case_log()

## Get all pages for current case
func get_case_pages(case_id: String = _current_case) -> Array:
	return _case_log.get(case_id, [])

## Get pages by category
func get_pages_by_category(category: String, case_id: String = _current_case) -> Array:
	var pages = []
	for page in _case_log.get(case_id, []):
		if page["category"] == category:
			pages.append(page)
	return pages

## Export case as formatted text (for printing/sharing)
func export_case_summary(case_id: String = _current_case) -> String:
	var summary = "═══════════════════════════════════════\n"
	summary += "DETECTIVE CHRONICLES - CASE SUMMARY\n"
	summary += "═══════════════════════════════════════\n\n"
	
	var clues = get_pages_by_category("clue", case_id)
	if clues.size() > 0:
		summary += "EVIDENCE COLLECTED (%d):\n" % clues.size()
		for clue in clues:
			summary += "  • %s\n" % clue["title"]
		summary += "\n"
	
	var theories = get_pages_by_category("theory", case_id)
	if theories.size() > 0:
		summary += "THEORIES DEVELOPED (%d):\n" % theories.size()
		for theory in theories:
			summary += "  • %s\n" % theory["title"]
		summary += "\n"
	
	var witnesses = get_pages_by_category("witness", case_id)
	if witnesses.size() > 0:
		summary += "WITNESSES INTERVIEWED (%d):\n" % witnesses.size()
		for witness in witnesses:
			summary += "  • %s\n" % witness["title"]
		summary += "\n"
	
	return summary

func save_case_log() -> void:
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	if file:
		file.store_var(_case_log)

func load_case_log() -> void:
	var file = FileAccess.open(_save_path, FileAccess.READ)
	if file:
		_case_log = file.get_var()
