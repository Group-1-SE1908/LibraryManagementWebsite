package com.lbms.model;

public class ShippingDetails {
    private String recipient;
    private String phone;
    private String street;
    private String residence;
    private String ward;
    private String district;
    private String city;
    

    public ShippingDetails() {
    }

    public ShippingDetails(String recipient, String phone, String street, String residence, String ward,
            String district, String city ) {
        this.recipient = recipient;
        this.phone = phone;
        this.street = street;
        this.residence = residence;
        this.ward = ward;
        this.district = district;
        this.city = city;
       
    }

    public String getRecipient() {
        return recipient;
    }

    public void setRecipient(String recipient) {
        this.recipient = recipient;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getResidence() {
        return residence;
    }

    public void setResidence(String residence) {
        this.residence = residence;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    
    

    public String getFormattedAddress() {
        StringBuilder builder = new StringBuilder();
        if (street != null && !street.isBlank()) {
            builder.append(street);
        }
        if (residence != null && !residence.isBlank()) {
            if (builder.length() > 0) {
                builder.append(", ");
            }
            builder.append(residence);
        }
        if (ward != null && !ward.isBlank()) {
            if (builder.length() > 0) {
                builder.append(", ");
            }
            builder.append(ward);
        }
        if (district != null && !district.isBlank()) {
            if (builder.length() > 0) {
                builder.append(", ");
            }
            builder.append(district);
        }
        if (city != null && !city.isBlank()) {
            if (builder.length() > 0) {
                builder.append(", ");
            }
            builder.append(city);
        }
        return builder.toString();
    }
}
