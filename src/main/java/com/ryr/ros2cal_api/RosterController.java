package com.ryr.ros2cal_api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/roster")
public class RosterController {

    @GetMapping("/convert")
    public ResponseEntity<String> convertRoster() {
        return ResponseEntity.ok("Sample roster conversion");
    }

    @GetMapping("/convert2")
    public ResponseEntity<String> convertRoster2() {
        return ResponseEntity.ok("Sample roster conversion 2");
    }
}
