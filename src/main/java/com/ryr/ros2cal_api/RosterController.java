package com.ryr.ros2cal_api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/roster")
public class RosterController {

    @GetMapping("/convert")
    public ResponseEntity<String> convertRoster() {
        return ResponseEntity.ok("Sample roster conversion");
    }
}
